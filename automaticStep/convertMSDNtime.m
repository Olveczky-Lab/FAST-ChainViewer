function [MATLABdatetime] = convertMSDNtime(MSDNdatetime)
% Convert from MSDN time to Matlab time
    MATLABdatetime = MSDNdatetime/(24*3600*1e7)+367;
end

