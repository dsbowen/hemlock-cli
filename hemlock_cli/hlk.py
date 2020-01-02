"""Hemlock command line interface

Commands are categorized as:
1. Initialization: initialize a new Hemlock project and utilities
2. Content: modify the project content
3. Deploy: commands related to deployment
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

"""1. Initialization"""
@click.command()
@click.argument('project')
@click.option(
    '-r', '--repo', default='https://github.com/dsbowen/hemlock-template.git',
    help='Existing project repository'
)
@export_args
def init(project):
    """Initialize Hemlock project"""
    call(['sh', SH_FILE, 'init'])

@click.command()
def tutorial():
    """Initialize tutorial"""
    os.environ['project'] = 'hemlock-tutorial'
    os.environ['repo'] = 'https://github.com/dsbowen/hemlock-tutorial.git'
    call(['sh', SH_FILE, 'init'])

@click.command('gcloud-bucket')
@click.argument('gcloud_billing_account')
@export_args
def gcloud_bucket(gcloud_billing_account):
    """Create google project and bucket"""
    call(['sh', SH_FILE, 'gcloud_bucket'])

"""2. Content"""
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
@click.option(
    '--debug', is_flag=True,
    help='Run the application in debug mode'
)
@export_args
def run(debug):
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

"""3. Deploy"""
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
def destroy():
    """Destroy application"""
    call(['sh', SH_FILE, 'destroy'])

hlk.add_command(init)
hlk.add_command(tutorial)
hlk.add_command(gcloud_bucket)
hlk.add_command(install)
hlk.add_command(shell)
hlk.add_command(run)
hlk.add_command(rq)
hlk.add_command(debug)
hlk.add_command(deploy)
hlk.add_command(production)
hlk.add_command(update)
hlk.add_command(destroy)

if __name__ == '__main__':
    hlk()