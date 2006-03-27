X=load('/home/wzj/LID/testscript/spd/b/test.logprob');
Y=load('/home/wzj/LID/testscript/spd/b/test.reflab');
[~,YY]=max(X,[],2);
YY=YY-1;
acc=100*sum(Y==YY)/length(Y);
fid = fopen('/home/wzj/LID/testscript/spd/b/test.acc','w');
fprintf(fid,'%6.2f%%\n',acc);
fclose(fid);
