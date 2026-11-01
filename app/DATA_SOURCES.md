# Data sources for development

The current expanded dataset is for local testing only. It must not be
published or distributed until the rights and licenses for every source have
been confirmed.

## Supplied sources

| File | Used for | Provenance status |
|---|---|---|
| `kanji-n4.md` | Kanji N4 fixture/import source | License not stated in file |
| `kotoba_pelajaran_26-50_per_bab.md` | Kotoba N4 fixture/import source | License not stated; refers to book scans |
| `PATOKAN_N3.md` | Kanji and kotoba N3 fixture/import source | License not stated; mentions KANJIDIC2 as a frequency reference |

These files were supplied locally for testing on 31 October 2026. The app
does not claim that their translations or selection are authoritative.

The current generated asset contains 2,517 cards: 292 Kanji N4, 539 Kanji N3,
1,085 Kotoba N4, and 585 Kotoba N3, in addition to the existing small N5 and
kana fixtures. Duplicate source entries are collapsed by stable content ID.

## Reproducible import

From `app`, run with Node.js:

```powershell
node tool\import_sources.mjs `
  --kanji-n4 C:\Users\Fahri\Downloads\kanji-n4.md `
  --kotoba-n4 C:\Users\Fahri\Downloads\kotoba_pelajaran_26-50_per_bab.md `
  --n3 C:\Users\Fahri\Downloads\PATOKAN_N3.md `
  --output assets\data\cards.json
```

The importer preserves existing stable fixture IDs and assigns deterministic
content-based IDs to imported rows. Review duplicates, translations, and licensing before
releasing the generated asset.

`tool/import_sources.py` contains the same parsing logic for environments that
provide Python, but Node.js is the supported runner in this workspace.
