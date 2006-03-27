X=load('/home/wzj/LID/testscript/version1.1/b/test.logprob');
Y=load('/home/wzj/LID/testscript/version1.1/b/test.reflab');
[~,YY]=max(X,[],2);
YY=YY-1;
fid = fopen('/home/wzj/LID/testscript/version1.1/b/test.rid','w');
for i = 1:1:length(Y)
fprintf(fid,'%d\n',YY(i));
end
fclose(fid);
acc=100*sum(Y==YY)/length(Y);
fid = fopen('/home/wzj/LID/testscript/version1.1/b/test.acc','w');
fprintf(fid,'%6.2f%%\n',acc);
fclose(fid);
