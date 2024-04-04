function varargout = process_nst_wMEM_metrics_RMSE( varargin )
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Compute RMSE';
    sProcess.FileTag     = '';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = {'Custom Processes','NIRS - wMEM'};
    sProcess.Index       = 20150;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'results'};
    sProcess.OutputTypes  = {'results'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.isSeparator = 0;
    
    
    % Definition of the options
    % === TARGET
    % File selection options
    SelectOptions = {...
        '', ...                            % Filename
        '', ...                            % FileFormat
        'save', ...                        % Dialog type: {open,save}
        'Save text file...', ... % Window title
        'ExportData', ...                  % LastUsedDir: {ImportData,ImportChannel,ImportAnat,ExportChannel,ExportData,ExportAnat,ExportProtocol,ExportImage,ExportScript}
        'single', ...                      % Selection mode: {single,multiple}
        'files', ...                        % Selection mode: {files,dirs,files_and_dirs}
        {{'.txt'}, 'text file', 'txt'}, ... % Available file formats
        []};                          % DefaultFormats: {ChannelIn,DataIn,DipolesIn,EventsIn,MriIn,NoiseCovIn,ResultsIn,SspIn,SurfaceIn,TimefreqIn}
    % Option: MRI file
    sProcess.options.textFile.Comment = 'Output folder:';
    sProcess.options.textFile.Type    = 'filename';
    sProcess.options.textFile.Value   = SelectOptions;
       
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end

function OutputFile = Run(sProcess, sInput)
    OutputFile = '';
    %% ===== RUN =====function OutputFile = Run(sProcess, sInput)
    % Load input file

    sF1 = in_bst_data(sInput(1).FileName);
    sF2 = in_bst_data(sInput(2).FileName);

    t0 = 358.3*1e-3;
    [~,idx] = min(abs(sF1.Time - t0));

    sA = sF1.ImageGridAmp(:, idx)*1e10;
    sB = sF2.ImageGridAmp(:, idx)*1e10;
    
    RMSE_mean = mean( (sA - sB).^2);
    RMSE_max = max( (sA - sB).^2);

    all_results = table(RMSE_mean,RMSE_max);

    %3. Save the results 
    writetable(all_results,sProcess.options.textFile.Value{1},'WriteMode','Append')
end
