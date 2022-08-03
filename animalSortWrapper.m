



% Calc clip sample length
preSample = ceil(PRE_TIME_MS*FQ_SAMPLE/1000);
postSample = ceil(POST_TIME_MS*FQ_SAMPLE/1000);
clipSize = max([preSample,postSample])*2;