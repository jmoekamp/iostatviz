#!/usr/local/bin/python3.8

import re
import sys, getopt
from datetime import datetime

def main(argv):
	inputfile = ''
	outputfile = ''
	try:
		opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
	except getopt.GetoptError:
		print('analyse.py -i <inputfile> -o <outputfile>')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('test.py -i <inputfile> -o <outputfile>')
			sys.exit()
		elif opt in ("-i", "--ifile"):
			inputfile = arg
		elif opt in ("-o", "--ofile"):
			outputfile = arg

	next_line_cpu = False
	next_line_noheader = False
	header = False
	first_date_set = False
	close_before_next = False
	splitted_here = False
	measurement = 0
	outfilepart = 0 

	iostat_file = open(inputfile, "r")
	
	for x in iostat_file:
		if measurement % 5000 == 0:
			if splitted_here == False:
				outfilepart = outfilepart + 1
				if outfilepart == 1: 
					outputfile_name = outputfile
				else:
					outputfile_name = outputfile + '.part' + str(int(outfilepart)) 
				if close_before_next == True:
					csv_file.close()
				csv_file = open(outputfile_name,"w")
				csv_file.write("rs,ws,krs,kws,wait,actv,wsvct,asvct,w,b,sw,hw,trn,tot,device,timestamp,us,sy,wt,id\n")
				close_before_next = True
				splitted_here = True
				print (splitted_here)
		# As there is no clear separator of measurements the timestamp 
		# is used as such by searching for time.
		if re.search(r' \d\d:\d\d:\d\d ',x):
			# Initialise timestamp with first date in file 
			if first_date_set == False:
				datestring = re.sub(r'\s+',' ', x.rstrip('\n'))
				convertedtime=datetime.strptime(datestring, '%a %b %d %H:%M:%S %Y')
				unix_timestamp=datetime.timestamp(convertedtime)
				print("First date: "+str(unix_timestamp))
			# Start header processing
			header = True
			# After timestamp has initialized, the timestamp isn't used anymore
			# This ensures that measurements have always an unique timestamp in further processing
			# even if they have duplicated timestamps due to time adjustments
			# done without skewing
			if first_date_set != True:
				first_date_set = True
				measurement_date = unix_timestamp
			else:
			    measurement_date = unix_timestamp + measurement
			measurement = measurement + 1
			splitted_here = False
		# r/s at the start of a line indicates that the after this line
		# we will see io data, thus the header of each measurement ended.
		if re.search(r'^r/s',x):
			next_line_noheader = True
		if next_line_cpu == True:	
			cpu_processed = x.split(',')
			cpu_us=cpu_processed[0]
			cpu_sy=cpu_processed[1]
			cpu_wt=cpu_processed[2]
			cpu_id=cpu_processed[3]
			next_line_cpu = False
		# us,sy,wt,id at the start of a line indicates that after this line
		# we will see cpu data
		if re.search(r'us,sy,wt,id',x):
			next_line_cpu = True
		# Print out everything that is not header 
		if header == False:
			iostatline = x.rstrip('\n')
			output = iostatline+','+str(int(measurement_date))+','+cpu_us+','+cpu_sy+','+cpu_wt+','+cpu_id
			csv_file.write(output)
		# Next line is not header, so end header processing
		if next_line_noheader == True:
			next_line_noheader = False
			header = False
	iostat_file.close()
	csv_file.close()
	print("Processed "+str(measurement)+" measurements")
			
if __name__ == "__main__":
   main(sys.argv[1:])