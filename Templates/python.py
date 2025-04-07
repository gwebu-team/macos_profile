#!/usr/bin/env uv run
#!/usr/bin/env python3
# Add -sPE to previous line for more security in system-wide installation.

"""Template for ..."""

# /// script
# dependencies = [
#   "textual",
# ]
# ///

import sys
from typing import Optional, Union
from shlex import split as shlex_split

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter, RawDescriptionHelpFormatter


class SmartFormatter(ArgumentDefaultsHelpFormatter, RawDescriptionHelpFormatter):
    """Smarter help formatter

    https://stackoverflow.com/questions/4375327 https://bugs.python.org/issue13041
    https://bugs.python.org/issue12806 + https://pypi.org/project/argparse-formatter/
    """

    def __init__(self, prog, indent_increment=2, max_help_position=24, width=None):
        try:
            import shutil
            width = shutil.get_terminal_size(fallback=(120, 32)).columns  # More reasonable nowadays @UndefinedVariable
        except AttributeError:
            width = 120
        super(SmartFormatter, self).__init__(prog, indent_increment, max_help_position, width)


class SmartArgumentParser(ArgumentParser):
    """Extended ArgumentParser"""

    def __init__(self, prog=None, usage=None, description=None, epilog=None, version=None, parents=[],
                 formatter_class=SmartFormatter, prefix_chars='-+', fromfile_prefix_chars='@', argument_default=None,
                 conflict_handler='error', add_help=True):
        ArgumentParser.__init__(self, prog=prog, usage=usage, description=description, epilog=epilog, parents=parents,
                                formatter_class=formatter_class, prefix_chars=prefix_chars,
                                fromfile_prefix_chars=fromfile_prefix_chars, argument_default=argument_default,
                                conflict_handler=conflict_handler, add_help=add_help)
        if version is not None:
            self.add_argument('--version', action='version', version='%(prog)s ' + version)

    def convert_arg_line_to_args(self, arg_line):
        """Split like shell, line by line, no EOL escaping"""
        try:
            return shlex_split(arg_line, comments=True)  # comments allowed
        except ValueError:
            return arg_line  # Best effort


def main() -> Optional[Union[int, str]]:
    """The main and only."""
    print("Hello world!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
