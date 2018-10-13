function [lbl,cost] = imgcut(src,snk,varargin)

% IMGCUT:  2-way graph cut on an image graph
%
% [lbl,cost] = imgcut(src,snk,d1,d2) is for a 2D image.
% src and snk represent link strengths from the pixel nodes.
% d1 and d2 represent the vertical and horizontal pixel neighbor links.
% If src and snk are MxN, d1 must be (M-1)xN and d2 is Mx(N-1).
% It does not handle multidimensional arrays.
%
% Uses Boykov/Kolmogorov algorithm:
%	"An Experimental Comparison of Min-Cut/Max-Flow Algorithms for Energy Minimization in Vision."
%	Yuri Boykov and Vladimir Kolmogorov.
%	In IEEE Transactions on Pattern Analysis and Machine Intelligence (PAMI), 
%	September 2004
% See http://www.cs.ucl.ac.uk/staff/V.Kolmogorov/software/maxflow-v3.01.src.tar.gz
% for download.

% This m-file should only run if there is not a compiled mex-file.
fprintf('Compiled mex-file not found.  Attempting to compile...\n');
try
    mex 'imgcut.cpp' 'graph.cpp' 'maxflow.cpp'
    fprintf('Compilation succeeded!\n');
    [lbl,cost] = imgcut(src,snk,varargin{:});
catch e
    fprintf('\nCompilation failed.\n');
    fprintf('\nPlease make sure that you have a supported compiler installed and configured.\n');
    fprintf('Also please ensure that all required source files are in the current working directory.\n');
    fprintf('Additional required source files may be available from the location(s) below:\n');
    fprintf('http://www.cs.ucl.ac.uk/staff/V.Kolmogorov/software/maxflow-v3.01.src.tar.gz (research license only)\n');
    fprintf('http://www.cs.ucl.ac.uk/staff/V.Kolmogorov/software/maxflow-v2.21.src.tar.gz (commercial license available)\n');
    fprintf('See http://www.cs.ucl.ac.uk/staff/V.Kolmogorov/software.html#MAXFLOW for more information.\n');
end
