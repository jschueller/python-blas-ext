from distutils.core import setup, Extension
setup(name = 'myModule', version = '1.0',  \
  packages=['myModule'], \
   ext_modules = [Extension('myModule.myModule',
                              libraries = ['cblas'],
                              sources=['test.c'])])
