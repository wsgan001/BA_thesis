using CSV, DataFrames

function importdata(filename)
    # import csv as DataFrame
    df = readtable(filename, header=false)

    # create Dict with new names
    newnames = Dict(
        :x1 => :antecedent,
        :x2 => :succedent,
        :x3 => :fakeprob,
        :x4 => :numofocc,
        :x5 => :dursec
    )

    # rename columns
    rename!(df, newnames)

    # return new DataFrame
    return df
end

function separatesuccedents(df)
    # add boolean columns to state whether only
    # mother or only infant are in the succedent
    df[:mother_succ] = false
    df[:infant_succ] = false

    # put appropriate booleans in mother_succ and infant_succ columns
    for i in size(df, 1):-1:1  # iterate backwards (not necessary anymore)
        succ = df[i,:succedent]
        # if the mother is not/only the infant is in the succedent
        if !(contains(succ, ";m") || contains(succ, "(m"))
            df[i,:infant_succ] = true
        else
            df[i,:infant_succ] = false
        end
        # if the infant is not/only the mother is in the succedent
        if !(contains(succ, ";i") || contains(succ, "(i"))
            df[i,:mother_succ] = true
        else
            df[i,:mother_succ] = false
        end
    end

    # create Dataframes with rules containing
    # only mother or only infant in the succedent
    df_infant = df[(df[:infant_succ] .== true),:]
    df_mother = df[(df[:mother_succ] .== true),:]

    # return new DataFrames
    return df_infant, df_mother
end

function writeseparateddfs(df_infant, df_mother, filename_infant, filename_mother)
    # store new Dataframes as csv
    writetable("filename_infant", df_infant)
    writetable("filename_mother", df_mother)
end
