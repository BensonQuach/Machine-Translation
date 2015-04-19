function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    % Initialize AM
    len = length(eng);
    
    for k=1:len
        eng_cell_sent = eng{k};
        fre_cell_sent = fre{k};
        len_eng = length(eng_cell_sent);
        len_fre = length(fre_cell_sent);
        for e=1:len_eng
            curr_eword = char(eng_cell_sent(e));
            if not(isfield(AM, curr_eword));
                AM.(curr_eword) = {};
            end
            for f=1:len_fre
                curr_fword = char(fre_cell_sent{f});
                if not(isfield(AM.(curr_eword), curr_fword))
                    AM.(curr_eword).(curr_fword) = 0;
                end
            end
        end
    end
    
    % Convert to vectors of possible french words to uniform probabilities.
    eng_fields = fieldnames(AM);
    eng_field_len = length(eng_fields);
    
    for a=1:eng_field_len
        curr_eng_field = eng_fields{a};
        
        fre_fields = fieldnames(AM.(curr_eng_field));
        fre_field_len = length(fre_fields);
        
        for b=1:fre_field_len
            curr_fre_field = fre_fields{b};
            AM.(curr_eng_field).(curr_fre_field) = 1 / fre_field_len;
        end
    end
    
    return
end