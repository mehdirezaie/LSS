import numpy as np
""" Copied from https://github.com/desihub/desitarget/blob/master/py/desitarget/cuts.py """
def isELG_colors(gflux=None, rflux=None, zflux=None, w1flux=None,
                 w2flux=None, south=True, primary=None):
    """Color cuts for ELG target selection classes
    (see, e.g., :func:`desitarget.cuts.set_target_bits` for parameters).
    """
    if primary is None:
        primary = np.ones_like(rflux, dtype='?')
    elg = primary.copy()

    # ADM work in magnitudes instead of fluxes. NOTE THIS IS ONLY OK AS
    # ADM the snr masking in ALL OF g, r AND z ENSURES positive fluxes.
    g = 22.5 - 2.5*np.log10(gflux.clip(1e-16))
    r = 22.5 - 2.5*np.log10(rflux.clip(1e-16))
    z = 22.5 - 2.5*np.log10(zflux.clip(1e-16))

    # ADM cuts shared by the northern and southern selections.
    elg &= g > 20                       # bright cut.
    elg &= r - z > 0.3                  # blue cut.
    elg &= r - z < 1.6                  # red cut.
    elg &= g - r < -1.2*(r - z) + 1.6   # OII flux cut.

    # ADM cuts that are unique to the north or south.
    if south:
        elg &= g < 23.5  # faint cut.
        # ADM south has the FDR cut to remove stars and low-z galaxies.
        elg &= g - r < 1.15*(r - z) - 0.15
    else:
        elg &= g < 23.6  # faint cut.
        elg &= g - r < 1.15*(r - z) - 0.35  # remove stars and low-z galaxies.

    return elg
