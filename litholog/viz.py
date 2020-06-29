"""
Visualization funcs and the `SequenceVizMixin` interface for `BedSequence`.
"""
from abc import ABC
from math import floor, ceil

from striplog import Legend
import matplotlib.pyplot as plt

from litholog import defaults
from litholog.wentworth import fine_scale, coarse_scale


def make_pair_figure():
    """
    Generate a figure with two column axes and no space horizontal between them.
    """
    fig, (ax1, ax2) = plt.subplots(ncols=2, sharey=True, figsize=(3*2, 10*3)) #subplot_kw=dict(frameon=False)
    fig.subplots_adjust(wspace=0.)

    return fig, (ax1, ax2)


def set_wentworth_ticks(ax, min_psi, max_psi, wentworth='fine', **kwargs):
    """Set the `xticks` of `ax` for Wentworth grainsizes.

    Parameters
    ----------
    ax : matplotlib.Axes
        Axes to modify.
    min_psi, max_psi: float
        Define the `xlim` for the axis.
    wentworth: one of {'fine', 'coarse'}
        Which scale to use. Default='fine'.
    **kwargs:

    """
    print(f'min_psi: {min_psi}')
    scale = coarse_scale if wentworth == 'coarse' else fine_scale

    scale_names, scale_psis = zip(*scale)

    minor_locs, minor_labels, major_locs = [], [], []

    for i in range(len(scale)):

        psi = scale_psis[i] if i != (len(scale)-1) else max(9, max_psi)
        prev_psi = scale_psis[i-1] if len(major_locs) > 0 else min_psi
        next_psi = scale_psis[i+1] if i < (len(scale)-2) else max_psi

        if psi <= min_psi:
            continue
        elif prev_psi >= max_psi:
            break

        print('(', prev_psi, ', ', psi, ', ', next_psi, ')')
        minor_locs.append((prev_psi + psi) / 2.)
        minor_labels.append(scale_names[i])

        major_locs.append(psi)

    ax.set_xticks(minor_locs, minor=True)
    ax.set_xticklabels(minor_labels, minor=True)

    ax.set_xticks(major_locs)
    ax.set_xticklabels(['']*len(major_locs))

    return ax


class SequenceVizMixin(ABC):
    """
    Defines the plot/viz interface for `BedSequence`.
    """
    def plot(self,
             legend=None,
             fig_width=1.5,
             aspect=10,
             width_field=None,
             depth_field=None,
             wentworth='fine',
             yticks_right=False,
             exxon_style=False,
             ax=None,
             **kwargs):
        """
        Plot as a `Striplog` of `Bed`s.

        Parameters
        ----------
        legend : striplog.Legend, optional
            If beds have primary `lithology` component, will use defaults.litholegend, otherwise random.
        fig_width : int, optional
            Width of figure, if creating one.
        aspect : int, optional
            Aspect ratio of figure, if creating one.
        width_field : str or in
            The `Bed.data` field or `Bed.values` column used to define polyon widths.
        depth_field :
            The `Bed.data` field or `Bed.values` column defining depths of `width_field` samples
        wentworth : one of {'fine', 'coarse'}
            Which Wentworth scale to use for xlabels/ticks.
        y_right : bool, optional
            If True, will move yticks/labels to right side. Defualt=False.
        exxon_style : bool, optional
            Set to true to invert the x-axis (so GS increases to the left).
        **kwargs : optional
            ylabelsize, yticksize, xlabelsize, x
        """
        if legend is None:
            # If beds have lithology, use litholegend
            if hasattr(self[0].primary, 'lithology'):
                legend = defaults.litholegend
            # Fall back to random legend if not
            else:
                legend = Legend.random(self.components)

        # Set up an ax if necessary
        if ax is None:
            return_ax = False
            fig = plt.figure(figsize=(fig_width, aspect*fig_width))
            ax = fig.add_axes([0.35, 0.05, 0.6, 0.95])
        else:
            return_ax = True

        ax.set_ylim([self.start.z, self.stop.z])

        # Determine xlimits
        if width_field:
            # Set from the data if possible
            min_width = floor(self.min_field(width_field) - 1)
            max_width = ceil(self.max_field(width_field) + 1)
        else:
            # Fall back to component decors if not

            min_width = min(d.width for d in legend) - 1
            max_width = legend.max_width + 1

        ax.set_xlim([min_width, max_width])
        set_wentworth_ticks(ax, min_width, max_width, wentworth=wentworth)

        # Tick params settable with kwargs
        ax.tick_params('y', which='major',
            labelsize=kwargs.get('ylabelsize', 16),
            ticksize=kwargs.get('yticksize', 16)
        )
        ax.tick_params('x', which='minor',
            labelsize=kwargs.get('xlabelsize', 12),
            labelrotation=kwargs.get('xlabelrotation', 60)
        )

        # Plot the individual Beds as patches
        for bed in self:
            ax.add_patch(bed.as_patch(legend, width_field, depth_field,
                                      min_width, max_width, **kwargs))

        # Finalize axis settings
        if self.order is 'depth':
            ax.invert_yaxis()

        if yticks_right:
            ax.yaxis.set_label_position('right')
            ax.yaxis.tick_right()

        if exxon_style:
            ax.invert_xaxis()

        if return_ax:
            return ax
