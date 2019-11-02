"""Hemlock command line interface"""

from subprocess import call
import click
import os

def sh_file():
    """Return path to shell file"""
    sh_path = os.path.dirname(os.path.abspath(__file__))
    return sh_path+'/hlk.sh'

def to_str(bool_var):
    """Convert boolean to 0/1 string"""
    return str(int(bool_var))

@click.group()
def hlk():
    pass

@click.command()
@click.argument('path')
def init(path):
    """Initialize Hemlock project"""
    call(['sh', sh_file(), 'init', path])

@click.command()
@click.argument('app')
@click.option(
    '--production/--debug', default=False, 
    help='Deploy in a production environment'
)
@click.option(
    '--worker/--no-worker', default=False,
    help='Employ background workers'
)
def deploy(app, production, worker):
    """Deploy application"""
    production = to_str(production)
    worker = to_str(worker)
    call(['sh', sh_file(), 'deploy', app, production, worker])

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

hlk.add_command(init)
hlk.add_command(deploy)
hlk.add_command(production)
hlk.add_command(update)
hlk.add_command(destroy)

if __name__ == '__main__':
    hlk()