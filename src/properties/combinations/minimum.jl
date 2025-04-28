# === CONVEX === #

function combine_properties_minimum(p1::Convex, p2::Convex)
    return nothing
end
n
function combine_properties_minimum(p1::Convex, p2::StronglyConvex)
    return nothing
end

function combine_properties_minimum(p1::StronglyConvex, p2::Convex)
    return nothing
end

function combine_properties_minimum(p1::Convex, p2::HypoConvex)
    return nothing
end

function combine_properties_minimum(p1::HypoConvex, p2::Convex)
    return nothing
end

function combine_properties_minimum(p1::Convex, p2::Smooth)
    return nothing
end

function combine_properties_minimum(p1::Smooth, p2::Convex)
    return nothing
end

function combine_properties_minimum(p1::Convex, p2::Lipschitz)
    return nothing
end

function combine_properties_minimum(p1::Lipschitz, p2::Convex)
    return nothing
end

function combine_properties_minimum(p1::Convex, p2::Linear)
    return nothing
end

function combine_properties_minimum(p1::Linear, p2::Convex)
    return nothing
end

function combine_properties_minimum(p1::Convex, p2::Quadratic)
    return nothing
end


function combine_properties_minimum(p1::Quadratic, p2::Convex)
    return nothing
end

# === STRONGLY CONVEX === #
function combine_properties_minimum(p1::StronglyConvex, p2::StronglyConvex)
    return nothing
end

function combine_properties_minimum(p1::StronglyConvex, p2::HypoConvex)
    return nothing
end

function combine_properties_minimum(p1::HypoConvex, p2::StronglyConvex)
    return nothing
end

function combine_properties_minimum(p1::StronglyConvex, p2::Smooth)
    return nothing
end

function combine_properties_minimum(p1::Smooth, p2::StronglyConvex)
    return nothing
end

function combine_properties_minimum(p1::StronglyConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_minimum(p1::Lipschitz, p2::StronglyConvex)
    return nothing
end

function combine_properties_minimum(p1::StronglyConvex, p2::Linear)
    return nothing
end

function combine_properties_minimum(p1::Linear, p2::StronglyConvex)
    return nothing
end

function combine_properties_minimum(p1::StronglyConvex, p2::Quadratic)
    return nothing
end

function combine_properties_minimum(p1::Quadratic, p2::StronglyConvex)
    return nothing
end

# === HypoConvex === #

function combine_properties_minimum(p1::HypoConvex, p2::HypoConvex)
    return nothing
end

function combine_properties_minimum(p1::HypoConvex, p2::Smooth)
    return nothing
end

function combine_properties_minimum(p1::Smooth, p2::HypoConvex)
    return nothing
end

function combine_properties_minimum(p1::HypoConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_minimum(p1::Lipschitz, p2::HypoConvex)
    return nothing
end

function combine_properties_minimum(p1::HypoConvex, p2::Linear)
    return nothing
end

function combine_properties_minimum(p1::Linear, p2::HypoConvex)
    return nothing
end

function combine_properties_minimum(p1::HypoConvex, p2::Quadratic)
    return nothing
end

function combine_properties_minimum(p1::Quadratic, p2::HypoConvex)
    return nothing
end

# === SMOOTH === #
function combine_properties_minimum(p1::Smooth, p2::Smooth)
    return nothing
end

function combine_properties_minimum(p1::Smooth, p2::Lipschitz)
    return nothing
end

function combine_properties_minimum(p1::Lipschitz, p2::Smooth)
    return nothing
end

function combine_properties_minimum(p1::Smooth, p2::Linear)
    return nothing
end

function combine_properties_minimum(p1::Linear, p2::Smooth)
    return nothing
end

function combine_properties_minimum(p1::Smooth, p2::Quadratic)
    return nothing
end

function combine_properties_minimum(p1::Quadratic, p2::Smooth)
    return nothing
end

# === LIPSCHITZ === #

function combine_properties_minimum(p1::Lipschitz, p2::Lipschitz)
    return nothing
end

function combine_properties_minimum(p1::Lipschitz, p2::Linear)
    return nothing
end

function combine_properties_minimum(p1::Linear, p2::Lipschitz)
    return nothing
end

function combine_properties_minimum(p1::Lipschitz, p2::Quadratic)
    return nothing
end

function combine_properties_minimum(p1::Quadratic, p2::Lipschitz)
    return nothing
end

# === LINEAR === #
function combine_properties_minimum(p1::Linear, p2::Linear)
    return nothing
end

function combine_properties_minimum(p1::Linear, p2::Quadratic)
    return nothing
end

function combine_properties_minimum(p1::Quadratic, p2::Linear)
    return nothing
end

# === QUADRATIC === #
function combine_properties_minimum(p1::Quadratic, p2::Quadratic)
    return nothing
end
