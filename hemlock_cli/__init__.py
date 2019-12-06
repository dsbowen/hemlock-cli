"""Hemlock command line interface"""

from subprocess import call
import click
import os

DIR = os.path.dirname(os.path.abspath(__file__))
SH_FILE = os.path.join(DIR, 'hlk.sh')

def to_str(bool_var):
    """Convert boolean to 0/1 string"""
    return str(int(bool_var))

@click.group()
def hlk():
    pass

@click.command()
@click.argument('assignment')
def config(assignment):
    """Set a configuration variable"""
    call(['sh', SH_FILE, 'config', assignment])

@click.command()
@click.argument('assignment')
@click.option(
    '--local', '-l',
    is_flag=True,
    help='Set local environment variable'
)
@click.option(
    '--production', '-p',
    is_flag=True,
    help='Set production environment variable'
)
@click.option(
    '--default', '-d',
    is_flag=True,
    help='Set default environment variable'
)
def export(assignment, local=False, production=False, default=False):
    """Set environment variable"""
    prod = production
    if not (local or prod):
        local = prod = True
    local, prod, default = to_str(local), to_str(prod), to_str(default)
    call(['sh', SH_FILE, 'export', assignment, local, prod, default])

@click.command()
@click.argument('project')
def init(project):
    """Initialize Hemlock project"""
    call(['sh', SH_FILE, 'init', project])

@click.command()
@click.argument('pkg_names', nargs=-1)
def install(pkg_names):
    """Install Python package"""
    call(['sh', SH_FILE, 'install', *pkg_names])

@click.command()
def shell():
    """Run Hemlock shell"""
    call(['sh', SH_FILE, 'shell'])

@click.command()
def run():
    """Run Hemlock locally"""
    call(['sh', SH_FILE, 'run'])

@click.command()
def rq():
    """Run Hemlock Redis Queue locally"""
    call(['sh', SH_FILE, 'rq'])

@click.command()
@click.argument('app')
def deploy(app):
    """Deploy application"""
    call(['sh', SH_FILE, 'deploy', app])

@click.command()
def update():
    """Update application"""
    call(['sh', SH_FILE, 'update'])

@click.command()
def production():
    """Convert to production environment"""
    call(['sh', SH_FILE, 'production'])

@click.command()
@click.option('--on/--off', default=True)
def worker(on):
    """Turn worker on or off"""
    call(['sh', SH_FILE, 'worker', to_str(on)])

@click.command()
def destroy():
    """Destroy application"""
    call(['sh', SH_FILE, 'destroy'])

hlk.add_command(config)
hlk.add_command(export)
hlk.add_command(init)
hlk.add_command(install)
hlk.add_command(shell)
hlk.add_command(run)
hlk.add_command(rq)
hlk.add_command(deploy)
hlk.add_command(production)
hlk.add_command(update)
hlk.add_command(worker)
hlk.add_command(destroy)

if __name__ == '__main__':
    hlk()