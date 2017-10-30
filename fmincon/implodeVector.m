function string=implodeVector(pieces,delimiter)
%IMPLODE    Joins strings with delimiter in between.
%   IMPLODE(PIECES,DELIMITER) returns a string containing all the
%   strings in PIECES joined with the DELIMITER string in between.
%
%   Input arguments:
%      PIECES - the pieces of string to join (numeric array)
%      DELIMITER - the delimiter string to put between the pieces (string)
%   Output arguments:
%      STRING - all the pieces joined with the delimiter in between (string)
%
%   Example:
%      PIECES = [1 3 5]
%      DELIMITER = '->'
%      STRING = IMPLODE(PIECES,DELIMITER)
%      STRING = 1->3->5
%
%   See also EXPLODE, STRCAT
%
%   Created: Sara Silva (sara@itqb.unl.pt) - 2002.08.25
%   Modified: Sara Silva (sara@dei.uc.pt) - 2005.03.11
%       - implode did not work if the delimiter was whitespace, so
%         line 36 was replaced by line 37.
%       - thank you to Matthew Davidson for pointing this out
%         (and providing the solution!)

if isempty(pieces) % no pieces to join, return empty string
   string='';
   
else % no need for delimiters yet, so far there's only one piece
   string=num2str(pieces(1));
end

l=length(pieces);
p=1;
while p<l % more than one piece to join with the delimiter, the interesting case
   p=p+1;
	%string=strcat(string,delimiter,pieces{p});
    string=[string delimiter num2str(pieces(p))];
end