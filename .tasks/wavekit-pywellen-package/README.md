# WaveKit PyWellen

`wavekit-pywellen` is a PyWellen distribution maintained for WaveKit, including APIs needed by WaveKit.

Install it with:

```bash
pip install wavekit-pywellen
```

Its Python import remains `pywellen`:

```python
from pywellen import Waveform
```

Do not install it together with upstream `pywellen`: both distributions install
the same `pywellen` module.
