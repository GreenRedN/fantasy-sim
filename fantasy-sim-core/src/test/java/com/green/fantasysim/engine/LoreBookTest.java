package com.green.fantasysim.engine;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class LoreBookTest {

    @Test
    void loadsDefaultWorldBibleA() {
        LoreBook lore = LoreBook.loadDefault();

        assertNotNull(lore);
        assertEquals("에르노스 대륙", lore.continent());
        assertEquals("태양성 교단", lore.churchName());
        assertEquals("월흑교", lore.demonWorshippersName());

        // Trade hints should exist for the major powers
        String desertTrade = lore.tradeHint("desert_kingdom");
        assertFalse(desertTrade.isBlank());
        assertTrue(desertTrade.contains("보석"));

        // Policy anchors
        assertTrue(lore.elfEntryPolicy().contains("허가"));
        assertTrue(lore.churchNorthDispatch().contains("북부"));

        // Relations: empire vs desert_kingdom is the canonical border tension
        LoreBook.Relation r = lore.relationBetween("empire", "desert_kingdom");
        assertNotNull(r);
        assertEquals("border_skirmish", r.type);
        assertNotNull(r.notes);
    }
}
