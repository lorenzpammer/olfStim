from ctypes import *
from ctypes import cdll, byref, create_string_buffer, pointer, POINTER, sizeof
sb = create_string_buffer(256)
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

ret = cdll.LASOM_LV.LASOM_LV_ParseSeqFile("ParseError.lsq")
print ret, " returned"
if (0 != ret) :
	ret = cdll.LASOM_LV.LASOM_LV_GetLastError2(sb, sizeof(sb))
	print "Last Error: ", sb.value
	num_lines = c_int()
	cdll.LASOM_LV.LASOM_LV_GetSeqNumParsedLines(byref(num_lines))
	cdll.LASOM_LV.LASOM_LV_GetSeqParseResult2(sb, sizeof(sb))
	print "Parse Result: ", sb.value
	print num_lines, " lines parsed"
