import colorama, re
from colorama import Fore, Style

VT100 = re.compile('\x1b\[[^m]*m')
def strip(s):
    return VT100.sub('',str(s))

def color(col, s):
    return f"{col}{s}{Style.RESET_ALL}"

def file(s):
    return color(Fore.BLUE, s)

def tool(s):
    return color(Fore.CYAN, s)

def error(s):
    return color(Fore.RED, s)

def warning(s):
    return color(Fore.YELLOW, s)

def success(s):
    return color(Fore.GREEN, s)
