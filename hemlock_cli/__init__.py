"""Hemlock command line interface"""

from subprocess import call
import click
import os

SH_FILE = os.path.dirname(os.path.abspath(__file__))+'/hlk.sh'

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
def shell():
    """Run Hemlock shell"""
    call(['sh', SH_FILE, 'shell'])

@click.command()
def run():
    """Run Hemlock locally"""
    call(['sh', SH_FILE, 'run'])

@click.command()
@click.argument('app')
def deploy(app):
    """Deploy application"""
    call(['sh', SH_FILE, 'deploy', app])

@click.command()
@click.option(
    '--worker/--no-worker', default=False,
    help='Employ background workers'
)
def production(worker):
    """Convert to production environment"""
    worker = to_str(worker)
    call(['sh', sh_file(), 'production', worker])

@click.command()
def update():
    """Update application"""
    call(['sh', sh_file(), 'update'])

@click.command()
def destroy():
    """Destroy application"""
    call(['sh', sh_file(), 'destroy'])

hlk.add_command(config)
hlk.add_command(export)
hlk.add_command(init)
hlk.add_command(shell)
hlk.add_command(run)
hlk.add_command(deploy)
hlk.add_command(production)
hlk.add_command(update)
hlk.add_command(destroy)

if __name__ == '__main__':
    hlk()