clear;clc;
File_path = '../CSE572_A2_data/';
File_directory = ["DM09"];
action_names = [ "About" ; "And";"Can";"Cop";"Deaf";"Decide";"Father";"Find";"Go out";"Hearing"];
post = '*.csv';
%action = strcat(File_path,action_names,post);%
%disp(length(action_names));
 for k=1:length(File_directory)
     output = convertStringsToChars(strcat("output2/",File_directory(k,:),".csv"));
    req_data=[];
    c=[];
    for d = 1:length(action_names)
        action = strcat(File_path,File_directory(k),'/',action_names(d),post);        
            Files=dir(convertStringsToChars(action));  
    File_path2 = convertStringsToChars(strcat(File_path,File_directory(k)));
    for i=1:length(Files)    
    full_filename = fullfile(File_path2,Files(i).name);
     [num_data,text_data] = xlsread(full_filename);
     numeric_data = transpose(num_data);
     [nrows,ncols] = size(numeric_data);
     if ncols < 50
        padding = 50-ncols;
        raw_data = padarray(numeric_data,[0,padding],0,'post');
     end   
     req_data = [req_data;raw_data(1:34,1:50)];
     headers = text_data(1,:); 
     for j=1:34
         data = headers(1,j);
         s=" ";
         info= strcat(action_names(d));
         c=[c;info]; 
     end  
    end
    end
    xlswrite(output,c,1,'A1');
    xlswrite(output,req_data,1,'B1');
    end