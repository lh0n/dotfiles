# This module requires python-xlib.
# Inspired by:
# https://github.com/qtile/qtile/wiki/screens#setup-multiple-screens-dynamically

from libqtile.log_utils import logger
from Xlib import display as xdisplay


def get_num_monitors() -> int:
    num_monitors = 0
    try:
        d = xdisplay.Display()
        s = d.screen()
        r = s.root.xrandr_get_screen_resources()

        for output in r.outputs:
            monitor = d.xrandr_get_output_info(output, r.config_timestamp)
            preferred = False
            if hasattr(monitor, "preferred"):
                preferred = monitor.preferred
            elif hasattr(monitor, "num_preferred"):
                preferred = monitor.num_preferred
            if preferred:
                num_monitors += 1
    except Exception:
        # always setup at least one monitor
        logger.exception('Failed to detect monitors.')
        return 1
    else:
        logger.info(f"Detected ({num_monitors}) monitors")
        return num_monitors
