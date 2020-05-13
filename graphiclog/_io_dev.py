"""
IO classes & functions.

This is an incomplete implemention of a more general/customizable
implementation of data checking/pre-processing.
"""
import operator
from abc import abstractmethod

import pandas as pd

from graphiclog import utils


class BaseCheck():
    """
    Base class for `Check` objects, which check something and take an action if the check fails.

    Parameters
    ----------
    check_fn : FunctionType
        Function that should return True if the check passes, False if it doesnt.
    action : FunctionType or Exception
        Action to take when `check_fn` fails (returns False).
        If function, will apply action to operand and return result.
        If Exception, will raise the Exception.
    """
    def __init__(self, check_fn, action):
        self.check_fn = check_fn
        self.action = action

    @property
    @abstractmethod
    def level(self):
        raise NotImplementedError

    def check(self, thing):
        return self.check_fn(thing)

    def apply(self, thing):
        """
        Application of `action` to a `thing` if `check_fn` returns False.
        """
        if not self.check(thing):
            if isinstance(self.action, Exception):
                raise self.action
            else:
                return self.action(thing)
        else:
            return thing


class RowCheck(BaseCheck):
    @property
    def level(self):
        return 'row'


class TableCheck(BaseCheck):
    @property
    def level(self):
        return 'group'


class DataFrameChecker():
    """
    Reads csv table(s) and applies a list of `Checks`
    """
    def __init__(self, checks, df=None, **kwargs):
        assert all(isinstance(chk, BaseCheck) for chk in checks), '`checks` must be an iterable of `Check`s'

        self.row_checks = [c for c in checks if c.level is 'row']
        self.group_checks = [c for c in checks if c.level is 'group']

        if df:
            if isinstance(df, pd.DataFrame):
                self.df = df
            else:
                self.df = self.read(df, **kwargs)

    @property
    def has_df(self):
        return isinstance(self.df, pd.DataFrame)


    def read(self, fpath, converters={}, **kwargs):
        try:
            return pd.read_csv(fpath, converters=converters, **kwargs)
        except UnicodeDecodeError:
            kwargs['encoding'] = 'latin-1'
            return pd.read_csv(fpath, converters=converters, **kwargs)


    def add_check(self, check):
        assert isinstance(check, BaseCheck), f'Can only add a `*Check`, not {type(check)}'
        if c.level is 'row':
            self.row_checks.append(check)
        elif c.level is 'group':
            self.group_checks.append(check)
        else:
            raise ValueError(f'Unknown `Check.level` value: {check.level}')


    def split_by(self, field):
        pass


def fill_column_nan(df, col, fill_value, indicator='missing'):
    """
    Fill missing values in `col` with `fill_value`.
    Add a new bool column '`indicator`_`col`'.
    """
    pass
