# MATLAB and STRAIGHT
MATLAB_HOME_PATH=/usr/local/matlab
MATLAB=${MATLAB_HOME_PATH}/bin/matlab -nodisplay -nosplash -nojvm

all: analysis

analysis: straight

straight:
	$(MATLAB) < matscripts/English.m 
	$(MATLAB) < matscripts/NorthMandarin.m 
	$(MATLAB) < matscripts/Uighur.m
