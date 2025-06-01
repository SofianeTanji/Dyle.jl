function register_special_functions()
    # Initialize special functions when oracles module loads
    if isdefined(Main, :SpecialFunctions)
        Main.SpecialFunctions.initialize_special_functions()
    end
end

function register_special_combinations() end
