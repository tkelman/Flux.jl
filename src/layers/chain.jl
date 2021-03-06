export Chain

function inferchain(ms)
  chain = []
  sh = nothing
  for m in ms
    m = init(m, single(sh))
    sh = shape(m, sh)
    push!(chain, m)
  end
  return chain, sh
end

type Chain <: Model
  layers::Vector{Any}
  shape
  function Chain(ms...)
    ms, shape = inferchain(ms)
    return new(ms, shape)
  end
end

@forward Chain.layers Base.getindex, Base.first, Base.last, Base.endof

(s::Chain)(x) = foldl((x, m) -> m(x), x, s.layers)
back!(s::Chain, Δ) = foldr((m, Δ) -> back!(m, Δ), Δ, s.layers)
update!(s::Chain, η) = foreach(l -> update!(l, η), s.layers)

graph(s::Chain) =
  foldl((v, m) -> vertex(m, v), constant(inputnode(1)), s.layers)

shape(c::Chain, in) = c.shape

Base.getindex(c::Chain, i::AbstractArray) = Chain(c.layers[i]...)
