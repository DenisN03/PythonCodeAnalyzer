Python Code Analyzer
========

This program is designed to improve code written in python.
The program uses the following packages:

1. pylint_
2. yapf_
3. isort_
4. autopep8_
5. autoflake_
6. radon_
7. pipreqs_

.. _pylint: https://github.com/PyCQA/pylint
.. _yapf: https://github.com/google/yapf
.. _isort: https://github.com/timothycrosley/isort
.. _autopep8: https://github.com/hhatto/autopep8
.. _autoflake: https://github.com/myint/autoflake
.. _radon: https://github.com/rubik/radon
.. _pipreqs: https://github.com/bndr/pipreqs

Usage

Program usage example::

    $ ./PythonCodeAnalyzer.sh [-e(--exclude)] [-d(--disable)] [-pw(--pkg-whitelist)] [-s(--save)] [-req(--requirements)] [-h(--help)]

where:
    -e   set the exclude path (only one folder support)
    -d   disable some pylint checks
    -pw  disable some imports from pylint checks (invalid-name)
    -s   saving a detailed report
    -req  generate requirements file for project
    -h   show this help text

In the future, the functionality of the program will expand.
