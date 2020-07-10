import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name='hemlock-cli',
    version='0.0.7',
    author='Dillon Bowen',
    author_email='dsbowen@wharton.upenn.edu',
    description='Command line interface for hemlock projects',
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://dsbowen.github.io/hemlock",
    packages=setuptools.find_packages(),
    include_package_data=True,
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
    install_requires=[
        'click>=7.0',
    ],
    entry_points='''
        [console_scripts]
        hlk=hemlock_cli:hlk
    '''
)