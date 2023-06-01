# -*- coding: utf-8 -*-

"""
Watch Netapp CDOT config changes and translate the changes into salt events
"""

# Import Python libs
from __future__ import absolute_import, unicode_literals

import logging

__virtualname__ = "netapp_config_checker"


log = logging.getLogger(__name__)


def __virtual__():
    return __virtualname__


def validate(config):
    """
    Validate beacon condig
    :param config: beacon config
    :return:config status
    """
    checks = ["svm", "firewall", "nis", "routes", "nfs", "dns"]

    if not isinstance(config, list):
        log.info("Configuration for netapp_config_checker beacon must be a list.")
        return False, "Configuration for netapp_config_checker beacon must be a list."

    _config = {}
    list(map(_config.update, config))

    if "checks" not in _config:
        log.info("Configuration for netapp_config_checker beacon must have checks key")
        return False, "Configuration for netapp_config_checker beacon must have check key."

    for i in _config["checks"]:
        if i not in checks:
            log.info("One or more check not available: %s", i)
            return False, "One or more check not available: {}".format(i)

    return True, "Valid beacon configuration"


def beacon(config):
    """
    Handle config checking
    :param config: list of checks
    :return: config difference

    .. code-block:: yaml

        beacons:
          netapp_config_checkers:
          - checks:
            - svm
          - disable_during_state_run: True
          - interval: 1
    """
    log.critical("Netapp config verify beacon called")

    _config = {}
    list(map(_config.update, config))

    return __salt__["na_cdot_config.verify"](_config["checks"])

