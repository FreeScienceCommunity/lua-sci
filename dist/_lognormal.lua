--------------------------------------------------------------------------------
-- Log-normal statistical distribution.
--
-- Copyright (C) 2011-2014 Stefano Peluchetti. All rights reserved.
--
-- Features, documentation and more: http://www.scilua.org .
--
-- This file is part of the SciLua library, which is released under the MIT 
-- license: full text in file LICENSE.TXT in the library's root folder.
--------------------------------------------------------------------------------

local xsys    = require "xsys"
local ffi     = require "ffi"
local _normal = require "sci.dist._normal"

local exp, log, sqrt, pi = xsys.from(math, 
     "exp, log, sqrt, pi")

local normal_sample = _normal.sample

local logn_mt = {
  __new = function(ct, mu, sigma)
    if not mu or not sigma then
      error("distribution parameters must be set at construction")
    end
    if sigma <= 0 then
      error("sigma must be positive, sigma is ", sigma)
    end
    return ffi.new(ct, mu, sigma)
  end,
  copy = function(self)
    return ffi.new(ffi.typeof(self), self)
  end,
  range = function(self)
    return 0, 1/0
  end,
  pdf = function(self, x)
    if x < 0 then return 0 end
    local mu, sigma = self._mu, self._sigma
    return exp(-(log(x) - mu)^2/(2*sigma^2)) / (x*sqrt(2*pi)*sigma)
  end,
  logpdf = function(self, x)
    if x < 0 then return -1/0 end
    local mu, sigma = self._mu, self._sigma
    return -(log(x) - mu)^2/(2*sigma^2) - log(x*sqrt(2*pi)*sigma)
  end,
  mean = function(self)
    return exp(self._mu + 0.5*self._sigma^2)
  end,
  var = function(self)
    return (exp(self._sigma^2) - 1)*exp(2*self._mu + self._sigma^2)
  end,
  sample = function(self, rng)
    return exp(normal_sample(self, rng))
  end,
}
logn_mt.__index = logn_mt

local dist = ffi.metatype("struct { double _mu, _sigma; }", logn_mt)

return {
  dist = dist,
}