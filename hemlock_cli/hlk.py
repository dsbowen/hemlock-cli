"""Hemlock command line interface

Commands are categorized as:
0. Setup: install recommended software for Ubuntu on WSL
1. Initialization: initialize a new hemlock project and utilities
2. Content: modify the project content
3. Deploy: commands related to deployment
"""

import click

import os
from functools import wraps
from subprocess import call

__version__ = '0.0.10'

DIR = os.path.dirname(os.path.abspath(__file__))
SH_FILE = os.path.join(DIR, 'hlk.sh')

@click.group()
@click.version_option(__version__)
@click.pass_context
def hlk(ctx):
    pass

"""0. Setup"""
@click.command()
@click.argument('OS')
@click.option(
    '--git', is_flag=True,
    help='Install git'
)
@click.option(
    '--chrome', is_flag=True,
    help='Set BROWSER environment variable pointing to chrome (WSL only)'
)
@click.option(
    '--chromedriver', is_flag=True,
    help='Install chromedriver'
)
@click.option(
    '--heroku-cli', is_flag=True,
    help='Install heroku command line interface'
)
def setup(os, git, chrome, chromedriver, heroku_cli):
    """Install recommended software"""
    if os not in ('win','wsl','mac','linux'):
        raise click.BadParameter('OS must be win, wsl, mac, or linux')
    args = (str(arg) for arg in (os, git, chrome, chromedriver, heroku_cli))
    if os == 'win':
        call(['sh', SH_FILE, 'setup', *args])
    else:
        call(['sudo', '-E', SH_FILE, 'setup', *args])

"""1. Initialization"""
@click.command()
@click.argument('project')
@click.option(
    '-r', '--repo', default='https://github.com/dsbowen/hemlock-template.git',
    help='Existing project repository'
)
def init(project, repo):
    """Initialize Hemlock project"""
    call(['sh', SH_FILE, 'init', project, repo])

@click.command('gcloud-bucket')
@click.argument('gcloud_billing_account')
def gcloud_bucket(gcloud_billing_account):
    """Create Google Cloud project and bucket"""
    call(['sh', SH_FILE, 'gcloud_bucket', gcloud_billing_account])

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
    '--n-batches', '-n', default=1,
    help='Number of AI participant batches'
)
@click.option(
    '--batch-size', '-s', default=1,
    help='Size of AI participant batches'
)
def debug(prod, n_batches, batch_size):
    """Run debugger"""
    call(['sh', SH_FILE, 'debug', prod, n_batches, batch_size])

"""3. Deploy"""
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