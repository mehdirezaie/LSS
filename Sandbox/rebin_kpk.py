'''
    The power spectrum measurements do not have the number of models per k bin
    This scripts, rebins the measurements, and adds that column

    To run (loop over mock ids) 
    > for i in {3..100};do python rebin_kpk.py /home/mehdi/data/mocksys/v0.5/pk_v0_${i}_red_1_0.5.txt /home/mehdi/data/mocksys/v0.6/pk_v0_${i}_red_1_0.6.txt;done

'''


import sys
import numpy as np

from scipy.stats import binned_statistic


def rebin(kin, p0, p2, p4, modes, kout):
    ''' Rebins the measurements 
    '''
    kwargs = dict(statistic='sum', bins=kout)
    
    bmodes,_,_   = binned_statistic(kin, modes,    **kwargs)    
    p0modes,_,_  = binned_statistic(kin, p0*modes, **kwargs)
    p2modes,_,_  = binned_statistic(kin, p2*modes, **kwargs)
    p4modes,_,_  = binned_statistic(kin, p4*modes, **kwargs)

    p0new = p0modes/bmodes
    p2new = p2modes/bmodes
    p4new = p4modes/bmodes
    
    return (kout[:-1], p0new, p2new, p4new, bmodes)

def read(inputFile):
    
    k = []
    p0= []
    p2= []
    p4= []
    comments = []
    
    with open(inputFile, 'r') as file:
        lines = file.readlines()
        for i,line in enumerate(lines):
            if line.startswith('#'):
                comments.append(line)
            else:
                dummy = line.split(' ')
                k.append(float(dummy[0]))
                p0.append(float(dummy[1]))
                p2.append(float(dummy[2]))
                p4.append(float(dummy[3]))
                #print(i, line, k, p0, p2, p4)

    k  = np.array(k)
    p0 = np.array(p0)
    p2 = np.array(p2)
    p4 = np.array(p4)
    
    return k, p0, p2, p4, comments


def main(sys):
    
    inputFile  = sys.argv[1]
    outputFile = sys.argv[2]    
    
    dk = 0.005 #float(sys.argv[3])
    
    # k_min, number of modes -- which is missing in v0.5 txt files
    kin, modes = np.loadtxt('/home/mehdi/data/mocksys/kmodes.txt', unpack=True)
    
    # read k, p0, p2, p4
    kinp, p0, p2, p4, comments = read(inputFile)
    
    assert np.array_equal(kin, kinp)
    del kinp
    
    kmin  = kin.min()
    kmax  = kin.max()
    dkold = kin[1]-kin[0]
    
    kout   = np.arange(kmin, kmax+dk, dk)
    kpknew = rebin(kin, p0, p2, p4, modes, kout)
    
    # save
    
    
    # test
    test = 1  # 0 or 1
    if test:
        import matplotlib as mpl
        mpl.use('Agg')
        import matplotlib.pyplot as plt
        
        kw = dict(marker='o', alpha=0.8)
        plt.loglog(kin, p0, **kw)
        plt.loglog(kpknew[0], kpknew[1], **kw)
        outputFig = outputFile.replace('.txt', '.png')
        plt.savefig(outputFig)
        print('plot .. %s'%outputFig)
    
    with open(outputFile, 'w') as file:
        file.write(f'# Original kmin, kmax, dk : {kmin:.4f}, {kmax:.4f}, {dkold:.4f}\n')
        file.write(f'# From original file {inputFile} \n')
        file.write('# last column is number of modes\n')
        for line in comments:
            file.write(line)
        
        # kmin, p0, p2, p4, modes
        for i in range(len(kpknew[0])):
            file.write(f'{kpknew[0][i]:.6f} {kpknew[1][i]:.6f} {kpknew[2][i]:.6f} {kpknew[3][i]:.6f} {kpknew[4][i]:.6f}\n')
            
    print("DONE!")
    
        
    
if __name__ == '__main__':
    main(sys)
