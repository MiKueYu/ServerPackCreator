/* Copyright (C) 2022  Griefed
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
 * USA
 *
 * The full license can be found at https:github.com/Griefed/ServerPackCreator/blob/main/LICENSE
 */
package de.griefed.serverpackcreator.versionmeta.fabric;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.net.URL;
import java.util.Optional;
import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

/**
 * Acquire details for a Fabric loader of a given Minecraft and Fabric version.
 *
 * @author Griefed
 */
final class FabricLoaderDetails {

  private final ObjectMapper OBJECT_MAPPER;

  /**
   * @param objectMapper Object mapper for JSON parsing.
   * @author Griefed
   */
  @Contract(pure = true)
  FabricLoaderDetails(ObjectMapper objectMapper) {
    OBJECT_MAPPER = objectMapper;
  }

  /**
   * Get the details for a given Minecraft and Fabric version combination.
   *
   * @param minecraftVersion Minecraft version.
   * @param modloaderVersion Fabric version,
   * @return Details for a given Minecraft and Fabric version combination, wrappen in an
   * {@link Optional}.
   * @author Griefed
   */
  @NotNull Optional<FabricDetails> getDetails(@NotNull String minecraftVersion,
                                              @NotNull String modloaderVersion) {
    try {
      return Optional.of(
          OBJECT_MAPPER.readValue(
              new URL(
                  "https://meta.fabricmc.net/v2/versions/loader/"
                      + minecraftVersion
                      + "/"
                      + modloaderVersion
                      + "/server/json"),
              FabricDetails.class));

    } catch (IOException e) {

      return Optional.empty();
    }
  }
}
