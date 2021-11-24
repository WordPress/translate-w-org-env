-- Generation Time: Nov 22, 2021 at 09:46 AM

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `translate`
--

-- --------------------------------------------------------

--
-- Table structure for table `translate_project_translation_status`
--

CREATE TABLE `translate_project_translation_status` (
  `id` int(10) UNSIGNED NOT NULL,
  `project_id` int(10) UNSIGNED NOT NULL,
  `locale` varchar(10) NOT NULL,
  `locale_slug` varchar(255) NOT NULL,
  `all` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `current` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `waiting` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `fuzzy` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `warnings` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `untranslated` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `date_added` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `translate_project_translation_status`
--
ALTER TABLE `translate_project_translation_status`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `project_locale` (`project_id`,`locale`,`locale_slug`),
  ADD KEY `all` (`all`),
  ADD KEY `current` (`current`),
  ADD KEY `waiting` (`waiting`),
  ADD KEY `fuzzy` (`fuzzy`),
  ADD KEY `warnings` (`warnings`),
  ADD KEY `untranslated` (`untranslated`),
  ADD KEY `locale` (`locale`,`locale_slug`),
  ADD KEY `date_added` (`date_added`),
  ADD KEY `date_modified` (`date_modified`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `translate_project_translation_status`
--
ALTER TABLE `translate_project_translation_status`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=507599043;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
