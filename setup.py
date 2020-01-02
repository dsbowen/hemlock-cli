import setuptools

setuptools.setup(
    name='hemlock-cli-dsbowen',
    version='0.0.1',
    author='Dillon Bowen',
    author_email='dsbowen@wharton.upenn.edu',
    description='Command line interface for Hemlock projects',
    packages=setuptools.find_packages(),
    include_package_date=True,
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
    install_requires=['Click'],
    entry_points='''
        [console_scripts]
        hlk=hlk:hlk
    '''
)