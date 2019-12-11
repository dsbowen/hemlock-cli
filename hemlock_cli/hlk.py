"""Hemlock command line interface

Commands are categorized as:
1. Environment: modify environment variables
2. Initialization: initialize a new Hemlock project
3. Content: modify the project content
4. Deploy: commands related to deployment
"""

from functools import wraps
from subprocess import call
import click
import os

DIR = os.path.dirname(os.path.abspath(__file__))
SH_FILE = os.path.join(DIR, 'hlk.sh')

def export_args(func):
    """Update environment variables with bash arguments"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        env = {key: str(val) for key, val in kwargs.items()}
        os.environ.update(env)
        return func(*args, **kwargs)
    return wrapper

@click.group()
def hlk():
    pass

"""1. Environment"""
@click.command()
@click.argument('assignments', nargs=-1)
@click.option(
    '--config', '-c', is_flag=True,
    help='Set configuration variable'
)
@click.option(
    '--local', '-l', is_flag=True,
    help='Set local environment variable'
)
@click.option(
    '--prod', '-p', is_flag=True,
    help='Set production environment variable'
)
@click.option(
    '--default', '-d', is_flag=True,
    help='Set default environment variable'
)
@export_args
def export(**kwargs):
    """Set an environment variable"""
    call(['sh', SH_FILE, 'export'])

@click.command()
@click.argument('vars', nargs=-1)
@click.option(
    '--config', '-c', is_flag=True,
    help='Unset configuration variable'
)
@click.option(
    '--local', '-l', is_flag=True,
    help='Unset local environment variable'
)
@click.option(
    '--prod', '-p', is_flag=True,
    help='Unset production environment variable'
)
@click.option(
    '--default', '-d', is_flag=True,
    help='Unset default environment variable'
)
@export_args
def unset(**kwargs):
    """Unset an environment variable"""
    call(['sh', SH_FILE, 'unset'])

"""2. Initialization"""
@click.command()
@click.argument('project')
@export_args
def init(project):
    """Initialize Hemlock project"""
    call(['sh', SH_FILE, 'init'])

"""3. Content"""
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
@click.option(
    '--local/--prod', default=True,
    help='Debug in a local or production(-lite) environment'
)
@click.option(
    '--num-batches', '-b', default=1,
    help='Number of AI participant batches'
)
@click.option(
    '--batch-size', '-s', default=1,
    help='Size of AI participant batches'
)
@export_args
def debug(local, num_batches, batch_size):
    """Run debugger"""
    call(['sh', SH_FILE, 'debug'])

"""4. Deploy"""
@click.command()
@click.argument('app')
@export_args
def deploy(app):
    """Deploy application"""
    call(['sh', SH_FILE, 'deploy'])

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
@export_args
def worker(on):
    """Turn worker on or off"""
    call(['sh', SH_FILE, 'worker'])

@click.command()
def destroy():
    """Destroy application"""
    call(['sh', SH_FILE, 'destroy'])

hlk.add_command(export)
hlk.add_command(unset)
hlk.add_command(init)
hlk.add_command(install)
hlk.add_command(shell)
hlk.add_command(run)
hlk.add_command(rq)
hlk.add_command(debug)
hlk.add_command(deploy)
hlk.add_command(production)
hlk.add_command(update)
hlk.add_command(worker)
hlk.add_command(destroy)

if __name__ == '__main__':
    hlk()