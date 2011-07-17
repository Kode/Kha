package com.kontechs.kje.backends.gwt;

import com.google.gwt.core.client.GWT;
import com.google.gwt.resources.client.ClientBundle;
import com.google.gwt.resources.client.ImageResource;

public interface Resources extends ClientBundle {
        public static Resources INSTANCE = GWT.create(Resources.class);

        @Source(value = { "texture.png" })
        ImageResource texture();
}