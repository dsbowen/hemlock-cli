"""Hemlock command line interface

Commands are categorized as:
0. Setup: install recommended software for Ubuntu on WSL
1. Initialization: initialize a new Hemlock project and utilities
2. Content: modify the project content
3. Deploy: commands related to deployment
"""

import click

import os
from functools import wraps
from subprocess import call
from os import environ

__version__ = '0.0.7'

DIR = os.path.dirname(os.path.abspath(__file__))
SH_FILE = os.path.join(DIR, 'hlk.sh')

def export_args(func):
    """Update environment variables with bash arguments"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        environ.update({key: str(val) for key, val in kwargs.items()})
        return func(*args, **kwargs)
    return wrapper

@click.group()
@click.version_option(__version__)
@click.pass_context
def hlk(ctx):
    pass

"""0. Setup"""
@click.command()
@click.argument('OS')
@click.option(
    '--all', is_flag=True,
    help='Install all recommended software'
)
@click.option(
    '--vscode', is_flag=True,
    help='Install Visual Studio Code'
)
@click.option(
    '--heroku-cli', is_flag=True,
    help='Install Heroku command line interface'
)
@click.option(
    '--git', is_flag=True,
    help='Install git'
)
@click.option(
    '--chrome', is_flag=True,
    help='Set chrome as your default browser (WSL only)'
)
@click.option(
    '--chromedriver', is_flag=True,
    help='Install chromedriver'
)
@click.option(
    '--cloud-sdk', is_flag=True,
    help='Install cloud-sdk'
)
@export_args
def setup(os, all, vscode, heroku_cli, git, chrome, chromedriver, cloud_sdk):
    """Install recommended software"""
    if os not in ('win','mac','linux'):
        raise click.BadParameter('OS must be win, mac, or linux')
    if os != 'win':
        raise click.BadParameter('Hemlock setup for mac and linux coming soon')
    if all:
        environ.update({
            key: 'True' for key in [
                'vscode', 
                'heroku_cli', 
                'git', 
                'chrome', 
                'chromedriver', 
                'cloud_sdk',
            ]
        })
    call(['sudo', '-E', SH_FILE, 'setup'])

"""1. Initialization"""
@click.command()
@click.argument('project')
@click.option(
    '-r', '--repo', default='https://github.com/dsbowen/hemlock-template.git',
    help='Existing project repository'
)
@export_args
def init(project, repo):
    """Initialize Hemlock project"""
    call(['sh', SH_FILE, 'init'])

@click.command()
def tutorial():
    """Initialize tutorial"""
    environ['project'] = 'hemlock-tutorial'
    environ['repo'] = 'https://github.com/dsbowen/hemlock-tutorial.git'
    call(['sh', SH_FILE, 'init'])

@click.command('gcloud-bucket')
@click.argument('gcloud_billing_account')
@export_args
def gcloud_bucket(gcloud_billing_account):
    """Create Google Cloud project and bucket"""
    call(['sh', SH_FILE, 'gcloud_bucket'])

"""2. Content"""
@click.command()
@click.argument('pkg_names', nargs=-1)
def install(pkg_names):
    """Install Python package"""
    call(['sh', SH_FILE, 'install', *pkg_names])

@click.command()
def serve():
    """Run Hemlock project locally"""
    call(['sh', SH_FILE, 'serve'])

@click.command()
def rq():
    """Run Hemlock Redis Queue locally"""
    call(['sh', SH_FILE, 'rq'])

@click.command()
@click.option(
    '--prod', is_flag=True,
    help='Debug in the production(-lite) environment on heroku'
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
def debug(prod, num_batches, batch_size):
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
def restart():
    """Restart application"""
    call(['sh', SH_FILE, 'restart'])

@click.command()
def production():
    """Convert to production environment"""
    call(['sh', SH_FILE, 'production'])

@click.command()
def destroy():
    """Destroy application"""
    call(['sh', SH_FILE, 'destroy'])

hlk.add_command(setup)
hlk.add_command(init)
hlk.add_command(tutorial)
hlk.add_command(gcloud_bucket)
hlk.add_command(install)
hlk.add_command(serve)
hlk.add_command(rq)
hlk.add_command(debug)
hlk.add_command(deploy)
hlk.add_command(production)
hlk.add_command(update)
hlk.add_command(restart)
hlk.add_command(destroy)

if __name__ == '__main__':
    hlk()