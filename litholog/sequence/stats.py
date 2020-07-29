# Stats for beds

import numpy as np

def mean_gs(Bed):
    """
    Find thickness-weighted mean of grain size for a bed
    """
    return np.average(Bed.data['grain_size_psi'], weights=Bed.data['depth_m'])
# Note - might be better to do this at the Sequence scale due to accessing data using "get_field"

def max_gs(Bed):
    """
    Find maximum grain size value for a bed
    """
    return np.amax(Bed.data['grain_size_psi'])
# Note - might be better to do this at the Sequence scale due to accessing data using "get_field"

def net_to_gross(BedSequence):
    """
    Find sand percentage (i.e., net-to-gross) of a Sequence
    """
    th = seq.get_field('th')
    maxgs = seq.get_field('max_gs_psi')
    sandth = th[maxgs>-4]
    mudth = th[maxgs<=-4]
    totalth = np.sum(seq.get_field('th')) # NEED TO UPDATE WITH MISSING LITHOLOGY!!
    # totalth=totalth minus missing th
    ntg=np.sum(sandth)/totalth
    return ntg

def amalgamation_ratio(BedSequence):
    """
    Find amalgamation ratio of a Sequence (see definition in this paper https://doi.org/10.1111/j.1365-3091.2008.00995.x)
    """
    1. dont count mud on mud contacts
    2. find sand on sand contacts
    3. divide sand-on-sand contacts by total number of contacts
    return ar

def lith_blocks(BedSequence):
    """
    Find uninterupted blocks of a lithology
    """
    1. find sand-on-sand contacts
    2. sum thickness of those beds

    return blocks


class SequenceStatsMixin(ABC):
    """
    Defines the plot/viz interface for `BedSequence`.
    """
    @property
    def interfaces(self):
        """
        Get all pairs of adjacent Beds, ignoring any pairs with either Bed 'missing'
        """
        non_missing = lambda t: 'missing' not in [t[0].lithology, t[1].lithology]
        return filter(non_missing, zip(self[:-1], self[1:]))

    @property
    def net_to_gross(self):
        """
        Returns (total thickness of 'sand' Beds) / (total thickness of all Beds)
        """
        is_sand = lambda bed: bed.lithology == 'sand'
        sand_th = sum([bed.thickness for bed in filter(is_sand, self)])

        not_missing = lambda bed: bed.lithology != 'missing'
        total_th = sum([bed.thickness for bed in filter(not_missing, self)])

        return sand_th / total_th


    @property
    def amalgamation_ratio(self):
        """
        1. dont count mud on mud contacts
        2. find sand on sand contacts
        3. divide sand-on-sand contacts by total number of contacts
        """
        total_contacts, sand_contacts = 0, 0
        for upper, lower in self.interfaces:
            if upper.lithology == lower.lithology == 'sand':
                sand_contacts += 1
            elif upper.lithology == lower.lithology == 'mud':
                continue
            elif upper.lithology == 'missing' or lower.lithology == 'missing':
                continue
            total_contacts += 1

        try:
            return sand_contacts / total_contacts
        except ZeroDivisionError:
            return 0.


    def hurst_K(self, field, safe=True):
        """
        Hurst K value for data from a sequence ``field``.

        If ``safe``, will only accept fields with at least 20 values.
        """
        values = self.get_field(field)

        return self._hurst_K(values, safe=safe)


    def hurst_D(self, field, safe=True, nsamples=1000, return_K=True):
        """
        Returns (K, D, p) if ``return_K``, else (D, p)
        where:
            K : Hurst K value with original values
            D : Bootstrapped Hurst value from ``nsamples`` resamples
            p : p-value of ``D``
        """
        values = self.get_field(field)
        K = self._hurst_K(values, safe=safe)

        ks = np.zeros(nsamples)
        for i in range(nsamples):
            _sample = np.random.choice(values, size=values.size, replace=True)
            ks[i] = self._hurst_K(_sample, safe=safe)

        D = (ks - ks.mean()) / ks.std()
        p = np.sum(ks >= K) / nsamples

        return (K, D, p) if return_K else (D, p)


    @staticmethod
    def _hurst_K(x, safe=True):
        """
        Computes Hurst K ``log(R(n)/S(n)) / log(x.size / 2)`` for 1D array ``x``
        """
        x = np.array(x).squeeze()
        assert x.ndim == 1, 'Can only compute _rescaled_range on 1D series `x`'
        if safe and x.size < 20:
            raise UserWarning(f'Cannot use field of size {x.size} with ``safe=True``')

        y = x - x.mean()
        z = np.cumsum(y)

        Rn = z.max() - z.min()
        Sn = np.std(y)

        return np.log(Rn / Sn) / np.log(x.shape[0] / 2.)


%% Function Hurst Statistics: No. 1
% Compute Hurst K and D
% K = log10(R/S)/log10(N/2),
% R is range of departure from the mean
% S is standard deviation
% N is sample size
% D is deviation of K from the mean of many random shuffling 'k', devidec % by the standard deviation of the many 'k'
% p is the p value of Hurst test
%% This function does not make plots
function [K, D, p] = hurst_k( x )
    if numel(x)<=20
       disp('---- Whoops! You may prefer a sample size larger than 20! But just calculate it for now ----');
    else
        % 1. Calculate K value
        x = x( x>0 );                    % x cannot be 0, cannot be 'NAN';
        x = x( ~isnan(x) );
        %x = log10(x);                    % log transform bed thickness;
        m = mean(x);                     % mean transformed bed thickness;
        dev = x - m;                     % deviations from the mean;
        cs = cumsum(dev);                % cumulated sum of the deviations;
        rr = max(cs)-min(cs);            % range of cumulated sum;
        s = std(x);                      % standard deviation;
        K = log10(rr/s) / log10(numel(x)/2);
        % 2. Calculate D value
        shuffle = 3000;                       %%%% HOW MANY TIMES OF SHUFFLING DO YOU NEED?
        k = zeros(1,shuffle);                   % store 'k' values for shuffled series
        for i = 1 : shuffle
            xx   = datasample(x, numel(x)); % uniformally resample with replacement;
            m = mean(xx);                   % mean of the sample;
            dev  = xx - m;                  % deviation from the mean;
            cs = cumsum(dev);               % cumulated sum;
            rr = max(cs)-min(cs);           % range of cumulated sum;
            s = std(xx);                    % standard deviation;
            k(i) = log10(rr/s) / log10(numel(xx)/2); % Hurst k for the sample;
        end
    K = transpose(K),                    % transpose K to look better;
    D = ( K-mean(k) ) / std(k),          % D: deviation from the mean k2;
    p = numel( find(k >= K) ) / shuffle,               % p: p-value of Hurst test
    end
end
%%
