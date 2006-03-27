X=load('/home/wzj/LID/testscript/version1.0/a/test.logprob');
Y=load('/home/wzj/LID/testscript/version1.0/a/test.reflab');
[~,YY]=max(X,[],2);
YY=YY-1;
fid = fopen('/home/wzj/LID/testscript/version1.0/a/test.rid','w');
for i = 1:1:length(Y)
fprintf(fid,'%d\n',YY(i));
end
fclose(fid);
acc=100*sum(Y==YY)/length(Y);
fid = fopen('/home/wzj/LID/testscript/version1.0/a/test.acc','w');
fprintf(fid,'%6.2f%%\n',acc);
fclose(fid);
