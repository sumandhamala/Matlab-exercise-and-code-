% for k=1:3
%     a(k)= k+1;
%     
%     path=fopen('suman.dat','w');
% 
% end

% for n=1:3
%     fprintf(path,'%15.6f\t',a(n));
%     fprintf(path,'\n');
% end
% fclose(path);
% Alu=importdata('suman.dat');
NameHead='demon';VVrf=4.45; real_freq=1; feedbackpoint=15794; NameIndex=1:2;
for   ii=1:2
name = sprintf('%s_%1i_*Vrf(%.4fV)*_Vcjj(%.4fV).dat',NameHead,NameIndex(ii),VVrf,Vcjj);
    filename=dir(name);
    DD=importdata(filename.name,'\t',20);
    Vrf=DD.data(:,1);
end
for k = 1 : 2
    
    % code to RUN PROGRAM and change phi...
    % Now save this phi in a new file.
    filename = sprintf('datafile_%02d.mat', k);
    message = sprintf('About to save phi into new file %s.', filename);
    uiwait(helpdlg(message));
    save(filename, 'phi');
end