# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from __future__ import print_function
from HDPGPHSMM_segmentaion import GPSegmentation
import time
import matplotlib.pyplot as plt
import os
import numpy as np
import pandas as pd
import glob

def learn( savedir, dim, gamma, eta, initial_class, avelen, maxlen, minlen, skiplen ):
    gpsegm = GPSegmentation( dim, gamma, eta, initial_class, avelen, maxlen, minlen, skiplen)

    files =  [ "data/oms_scaledpcs/dat_oms_%02d.txt" % j for j in range(29) ]
    gpsegm.load_data( files )
    liks = []

    start = time.time()
    #iteration (default: 10)
    for it in range( 50 ):
        print( "-----", it, "-----" )
        gpsegm.learn()
        numclass = gpsegm.save_model( savedir )
        print( "lik =", gpsegm.calc_lik() )
        liks.append(gpsegm.calc_lik())
    print ("liks: ",liks)
    print( time.time()-start )

    #plot liks
    plt.clf()
    plt.plot( range(len(liks)), liks )
    plt.savefig( os.path.join( savedir,"liks.png") )

    return numclass


def recog( modeldir, savedir, dim, gamma, eta, initial_class, avelen, maxlen, minlen, skiplen ):
    print ("class", initial_class)
    gpsegm = GPSegmentation( dim, gamma, eta, initial_class, avelen, maxlen, minlen, skiplen)

    gpsegm.load_data( [ "data/oms_scaledpcs/dat_oms_%02d.txt" % j for j in range(29) ] )
    gpsegm.load_model( modeldir )


    start = time.time()
    gpsegm.recog()
    print( "lik =", gpsegm.calc_lik() )
    print( time.time() - start )
    gpsegm.save_model( savedir )


def main():
  nums = 10
#    nums = range(10, 31, 5)
    for i in nums:
    #parameters
      dim = 2
      gamma = 3.0
      eta = 10.0

      initial_class = i

      avelen = 30
      maxlen = 70
      minlen = 10
      print(maxlen, minlen)
      skiplen = 1
      
      # GaussianProcess.pyx L38-42
      beta = 10.0
      theta0 = 0
      theta1 = 0
      theta2 = 1
      theta3 = 0

      # save dir
      path_learn = "data/learn_smp_init" + str(int(initial_class)) + "/"
      path_recog = "data/recog_smp_init" + str(int(initial_class)) + "/"
      path_numclass = path_learn + "num_class.txt"

      df = pd.DataFrame([dim, beta, theta0, theta1, theta2, theta3, gamma, eta, initial_class, avelen, maxlen, minlen, skiplen, path_learn, path_recog])
      df.columns = ["values"]
      df.index = ["dim", "beta", "theta0", "theta1", "theta2", "theta3", "gamma", "eta", "initial_class", "avelen", "maxlen", "minlen", "skiplen", "path_learn", "path_recog"]

    #learn
      print ( "=====", "learn", "=====" )
      num_class = learn(path_learn, dim, gamma, eta, initial_class, avelen, maxlen, minlen, skiplen)
      np.savetxt(path_numclass, [num_class])
      df.to_csv(path_learn + "params.csv")
    
    #recognition
      print ( "=====", "recognition", "=====" )
      num_class = int(np.loadtxt(path_numclass))
      recog(path_learn, path_recog, dim, gamma, eta, num_class, avelen, maxlen, minlen, skiplen)
      df.to_csv(path_recog + "params.csv")
    
    return

if __name__=="__main__":
    main()
