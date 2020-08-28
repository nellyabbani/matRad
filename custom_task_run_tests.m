function result = custom_task_run_tests(file)
%custom_task_run_tests - A project custom task.
%
% To create your own custom task, edit this function to perform the desired
% action on each file.
%
% Input arguments:
%  file - char array - The absolute path to a file included in the custom task.
%  When you run the custom task, the project provides the file input for each
%  selected file.
%
% Output arguments:
%  result - user-specified type - The result output argument of your custom task.
%  The project displays the result in the Custom Task Results column.
%
% To use the custom task from the project:
%  1) On the Project tab, click Custom Task.
%  2) Select the check boxes of project files you want to include in the custom task.
%  3) Click Select and choose your custom task from the list.
%  4) Click Run Task.
%
% An example is shown below, which extracts Code Analyzer information for
% each file.


[~,fname,ext] = fileparts(file);
if contains(fname, 'runTests')
    
    run(file);
else
    result = [];
end

end
