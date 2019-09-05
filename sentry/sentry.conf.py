# Copied from https://github.com/getsentry/onpremise/blob/master/sentry.conf.py
# except changed SENTRY_WEB_PORT=9000 -> SENTRY_WEB_PORT=env('PORT')
from sentry.conf.server import *  # NOQA
from sentry.utils.types import Bool, Int

import os
import os.path
import six

CONF_ROOT = os.path.dirname(__file__)

############
# Database #
############

DATABASES = {
    'default': {
        'ENGINE': 'sentry.db.postgres',
        'NAME': env('SENTRY_DB_NAME'),
        'USER': env('SENTRY_DB_USER'),
        'PASSWORD': env('SENTRY_DB_PASSWORD'),
        'HOST': env('SENTRY_POSTGRES_HOST'),
        'PORT': env('SENTRY_POSTGRES_PORT'),
    },
}

SENTRY_USE_BIG_INTS = True

###########
# General #
###########

SENTRY_SINGLE_ORGANIZATION = env('SENTRY_SINGLE_ORGANIZATION', True)
SENTRY_BEACON=False
SENTRY_WEB_PORT = env('PORT')
SENTRY_OPTIONS['system.secret-key'] = env('SENTRY_SECRET_KEY')

#########
# Redis #
#########

redis_password = env('REDIS_PASSWORD') or ''
redis_db = env('REDIS_DB') or '0'

SENTRY_OPTIONS.update({
    'redis.clusters': {
        'default': {
            'hosts': {
                0: {
                    'host': env('REDIS_TLS_HOST'),
                    'port': env('REDIS_TLS_PORT'),
                    'password': redis_password,
                    'db': redis_db,
                    'ssl': True,
                },
            },
        },
    },
})

# Kombu does not support Redis over TLS so use the REDIS_NON_TLS_* environment variables
BROKER_URL = 'redis://:' + redis_password + '@' + env('REDIS_NON_TLS_HOST') + ':' + env('REDIS_NON_TLS_PORT') + '/' + redis_db


############
# Defaults #
############

SENTRY_CACHE = 'sentry.cache.redis.RedisCache'
SENTRY_RATELIMITER = 'sentry.ratelimits.redis.RedisRateLimiter'
SENTRY_BUFFER = 'sentry.buffer.redis.RedisBuffer'
SENTRY_QUOTAS = 'sentry.quotas.redis.RedisQuota'
SENTRY_TSDB = 'sentry.tsdb.redis.RedisTSDB'
SENTRY_DIGESTS = 'sentry.digests.backends.redis.RedisBackend'
SENTRY_OPTIONS['filestore.backend'] = 'filesystem'
SENTRY_OPTIONS['filestore.options'] = {
    'location': env('SENTRY_FILESTORE_DIR'),
}
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SOCIAL_AUTH_REDIRECT_IS_HTTPS = True

SENTRY_WEB_HOST = '0.0.0.0'
SENTRY_WEB_OPTIONS = {
    'http': '%s:%s' % (SENTRY_WEB_HOST, SENTRY_WEB_PORT),
    'protocol': 'uwsgi',
    'uwsgi-socket': None,
    'http-keepalive': True,
    'memory-report': False,
}

if 'GITHUB_APP_ID' in os.environ:
    GITHUB_EXTENDED_PERMISSIONS = ['repo']
    GITHUB_APP_ID = env('GITHUB_APP_ID')
    GITHUB_API_SECRET = env('GITHUB_API_SECRET')
