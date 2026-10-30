-- Color math for the Xcode targets.
--
-- Xcode reads the "r g b a" strings in a .xccolortheme as macOS *Generic RGB*
-- (pure gamma 1.8, primaries close to sRGB), not as sRGB. Writing hex/255 would
-- display lighter and slightly shifted. Xcode's own .xcworkspacecolortheme
-- stores the same colors as OKLCH of the real (sRGB) color. Both facts were
-- checked against AppKit: NSColorSpace.genericRGB -> OKLCH reproduces the
-- values in a migrated .xcworkspacecolortheme to 5 decimals.
local M = {}

M.GENERIC_GAMMA = 1.8

-- Generic RGB (linear) -> linear sRGB, taken from AppKit by converting the
-- basis vectors; rows are the output channel, columns the input channel.
local GENERIC_TO_SRGB = {
  { 1.0252417326, -0.0265452433, 0.0013035525 },
  { 0.0194007643, 0.9480088353, 0.0325903520 },
  { -0.0017621303, -0.0014344937, 1.0031965971 },
}

local function mul(m, v)
  return m[1][1] * v[1] + m[1][2] * v[2] + m[1][3] * v[3],
    m[2][1] * v[1] + m[2][2] * v[2] + m[2][3] * v[3],
    m[3][1] * v[1] + m[3][2] * v[2] + m[3][3] * v[3]
end

local function invert(m)
  local a, b, c = m[1][1], m[1][2], m[1][3]
  local d, e, f = m[2][1], m[2][2], m[2][3]
  local g, h, i = m[3][1], m[3][2], m[3][3]
  local det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
  return {
    { (e * i - f * h) / det, (c * h - b * i) / det, (b * f - c * e) / det },
    { (f * g - d * i) / det, (a * i - c * g) / det, (c * d - a * f) / det },
    { (d * h - e * g) / det, (b * g - a * h) / det, (a * e - b * d) / det },
  }
end

local SRGB_TO_GENERIC = invert(GENERIC_TO_SRGB)

local function srgb_decode(c)
  return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
end

local function srgb_encode(c)
  return c <= 0.0031308 and c * 12.92 or 1.055 * c ^ (1 / 2.4) - 0.055
end

---@param hex string "#rrggbb"
---@return number, number, number sRGB components, 0..1
function M.hex_to_rgb(hex)
  local n = tonumber(hex:sub(2), 16)
  return math.floor(n / 65536) % 256 / 255, math.floor(n / 256) % 256 / 255, n % 256 / 255
end

function M.rgb_to_hex(r, g, b)
  local function byte(x)
    return math.floor(math.min(1, math.max(0, x)) * 255 + 0.5)
  end
  return ("#%02x%02x%02x"):format(byte(r), byte(g), byte(b))
end

--- Linear sRGB of a hex color.
function M.hex_to_linear(hex)
  local r, g, b = M.hex_to_rgb(hex)
  return srgb_decode(r), srgb_decode(g), srgb_decode(b)
end

--- The Generic RGB components that Xcode must be given to display `hex`.
--- Errors if the color is outside Generic RGB's gamut, rather than clipping silently.
---@return number, number, number
function M.generic_from_hex(hex)
  local lr, lg, lb = M.hex_to_linear(hex)
  local gr, gg, gb = mul(SRGB_TO_GENERIC, { lr, lg, lb })
  local out = {}
  for i, v in ipairs { gr, gg, gb } do
    if v < -1e-6 or v > 1 + 1e-6 then
      error(("%s is outside Generic RGB gamut (channel %d = %.4f)"):format(hex, i, v), 0)
    end
    out[i] = math.max(0, math.min(1, v)) ^ (1 / M.GENERIC_GAMMA)
  end
  return out[1], out[2], out[3]
end

--- The sRGB hex that Xcode displays for Generic RGB components.
function M.hex_from_generic(r, g, b)
  local lr, lg, lb = mul(GENERIC_TO_SRGB, { r ^ M.GENERIC_GAMMA, g ^ M.GENERIC_GAMMA, b ^ M.GENERIC_GAMMA })
  return M.rgb_to_hex(srgb_encode(lr), srgb_encode(lg), srgb_encode(lb))
end

--- OKLCH (lightness, chroma, hue in radians) from linear sRGB.
function M.oklch_from_linear(r, g, b)
  local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
  local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
  local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
  local l_, m_, s_ = l ^ (1 / 3), m ^ (1 / 3), s ^ (1 / 3)
  local L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
  local a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
  local bb = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
  local h = (math.atan2 or math.atan)(bb, a)
  if h < 0 then
    h = h + 2 * math.pi
  end
  return L, math.sqrt(a * a + bb * bb), h
end

---@param hex string
function M.oklch_from_hex(hex)
  return M.oklch_from_linear(M.hex_to_linear(hex))
end

--- OKLCH of what Xcode displays for Generic RGB components (what its migration stores).
function M.oklch_from_generic(r, g, b)
  return M.oklch_from_linear(mul(GENERIC_TO_SRGB, { r ^ M.GENERIC_GAMMA, g ^ M.GENERIC_GAMMA, b ^ M.GENERIC_GAMMA }))
end

--- Inverse of oklch_from_hex, used by the tests.
function M.hex_from_oklch(L, C, h)
  local a, b = C * math.cos(h), C * math.sin(h)
  local l_ = L + 0.3963377774 * a + 0.2158037573 * b
  local m_ = L - 0.1055613458 * a - 0.0638541728 * b
  local s_ = L - 0.0894841775 * a - 1.2914855480 * b
  local l, m, s = l_ ^ 3, m_ ^ 3, s_ ^ 3
  local r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
  local g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
  local bl = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
  return M.rgb_to_hex(srgb_encode(r), srgb_encode(g), srgb_encode(bl))
end

return M
