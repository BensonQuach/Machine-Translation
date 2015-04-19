function [eng, fre] = read_hansard(dir_path, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
% 
%   dir_path = '/u/cs401/A2_SMT/data/Hansard/Training/';
%   numSentences = 100

  eng = {};
  fre = {};

  % TODO: your code goes here.
  readSent = 0;
  
  data_dir_eng = dir([dir_path, './*e']);
  length_of_DD = length(data_dir_eng);
  
  for k=1:length_of_DD
      
      if not(data_dir_eng(k).isdir)
          curr_file_eng = data_dir_eng(k).name;
          curr_file_fre = [curr_file_eng(1:length(curr_file_eng) - 1), 'f'];
          
          eng_data = textread([dir_path, curr_file_eng], '%s', 'delimiter', '\n');
          fre_data = textread([dir_path, curr_file_fre], '%s', 'delimiter', '\n');
          
          for i=1:length(eng_data)
              readSent = readSent + 1;
              eng{readSent} = strsplit(' ', preprocess(char(eng_data(i)), 'e'));
              fre{readSent} = strsplit(' ', preprocess(char(fre_data(i)), 'f'));
              if readSent == numSentences
                  return
              end
          end
      end
  end
end 
