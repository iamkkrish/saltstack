"""
Salt execution module to push config backups to Gitlab config cache repo
"""

# Import standard libs
from __future__ import absolute_import

import logging

# Define the virtual name
__virtualname__ = 'snow'

# Define Logging
LOG = logging.getLogger(__name__)

# Import third party libs
try:
    import nvsnow
    import nvvault
    IMPORT_SUCCESSFUL = True
except ImportError:
    IMPORT_SUCCESSFUL = False


def __virtual__():
    """
    This execution module will work on ios devices
    """
    if IMPORT_SUCCESSFUL:
        return __virtualname__

    return (False, 'The pkg module could not be loaded: unable to import nvsnow and nvvault')


def get_secret(path):
    """
    Get secret from vault
    """
    try:
        return nvvault.get_secret(path=path)

    except Exception as err:
        raise Exception("Vault error: Unable to fetch "
                        "secret from Vault. Got Error: {}".format(err))


def create_incident(instance, short_description, description, path, **kwargs):
    """
    create a service request
    :param instance: service-now instance
    :param short_description: short description for ticket
    :param description: description for ticket
    :param path: path where secret is stored
    :param kwargs: additional key value arguments
    :return: ticket number
    """
    LOG.critical("Running SNOW reactor")
    secret = get_secret(path)
    c = nvsnow.Client(username=secret["username"], password=secret["password"], instance=instance)

    record = c.client.incident.create(
        short_description=short_description,
        description=description.replace(';', '\n'),
        **kwargs,
    )

    LOG.critical("Record: {}".format(record))
    LOG.critical("Sys id: {}".format(record.sys_id))
    LOG.critical("Number: {}".format(record.number))

    return record.number






