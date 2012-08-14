from ctypes import *
cdll.LoadLibrary("LASOM_LV")
ret = cdll.LASOM_LV.LASOM_LV_Open(0,0) # should return 0
if (0 != ret) :
	print "LASOM open failed, ret = ",ret
else :
	slave = 1
	valve_on = 1
	valve_off = 0
	cdll.LASOM_LV.LASOM_LV_SetOdorValve(slave,2,valve_on) # odor 2 on
	cdll.LASOM_LV.LASOM_LV_SetGateValve(slave,13,valve_on) # gate 13 on

