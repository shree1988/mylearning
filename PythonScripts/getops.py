import getopt
import sys

variant = '1.0'
debug = False
output_file = 'my_file.out'

print('ARGV      :', sys.argv[1:])

options, remainder = getopt.gnu_getopt(
    sys.argv[1:], 'o:v', ['output=', 'debug', 'variant=',])
print('OPTIONS   :', options)
for opt, arg in options:
    if opt in ('-o', '--output'):
        print('Setting --output.')
        output_file = arg
    elif opt in ('-d', '--debug'):
        print('Setting --debug.')
        debug = True
    elif opt == '--variant':
        print('Setting --variant.')
        variant = arg

print('VARIANT   :', variant)
print('DEBUG   :', debug)
print('OUTPUT    :', output_file)
print('REMAINING :', remainder)